// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

import React, { useCallback, useEffect, useState } from 'react';
import { Container, Form, Spinner } from 'react-bootstrap';
import {
  Outlet, useLocation, useNavigate, useSearchParams,
} from 'react-router-dom';
import i18next from 'i18next';
import { useTranslation } from 'react-i18next';
import { ToastContainer, toast } from 'react-toastify';
import Header from './components/shared_components/Header';
import { useAuth } from './contexts/auth/AuthProvider';
import Footer from './components/shared_components/Footer';
import useSiteSetting from './hooks/queries/site_settings/useSiteSetting';
import Title from './components/shared_components/utilities/Title';
import useEnv from './hooks/queries/env/useEnv';

export default function App() {
  const currentUser = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const { data: env } = useEnv();
  const autoSignIn = searchParams.get('sso');
  const [formElement, setFormElement] = useState(null);

  // The toasts are fixed to the viewport until the end of the page content, marked by the anchor
  // above the ToastContainer, scrolls into view. On phones they then sit above the footer, see
  // .toasts-docked.
  const [toastAnchor, setToastAnchor] = useState(null);
  const [toastsDocked, setToastsDocked] = useState(false);

  useEffect(() => {
    if (!toastAnchor || !('IntersectionObserver' in window)) return undefined;

    let anchorInView = false;
    // Only on a page that scrolls: on one that fits the screen the anchor is always in view. Docked
    // toasts are part of the page, so their height does not count.
    const update = () => {
      const { scrollHeight, clientHeight } = document.documentElement;
      const docked = document.querySelector('.Toastify__toast-container.toasts-docked');
      const dockedHeight = docked && getComputedStyle(docked).position === 'relative' ? docked.offsetHeight : 0;
      setToastsDocked(anchorInView && scrollHeight - dockedHeight > clientHeight);
    };

    const intersectionObserver = new IntersectionObserver(([entry]) => {
      anchorInView = entry.isIntersecting;
      update();
    });
    intersectionObserver.observe(toastAnchor);

    // The page height also changes while the anchor stays in view, e.g. on a tab switch.
    const resizeObserver = 'ResizeObserver' in window ? new ResizeObserver(update) : null;
    resizeObserver?.observe(document.body);

    return () => {
      intersectionObserver.disconnect();
      resizeObserver?.disconnect();
    };
  }, [toastAnchor]);

  // check for the maintenance banner
  const maintenanceBanner = useSiteSetting(['Maintenance']);

  // useEffect hook for running notify maintenance banner on page load
  useEffect(() => {
    if (maintenanceBanner.data) {
      const toastId = toast.info(<span dangerouslySetInnerHTML={{ __html: maintenanceBanner.data }} />, {
        position: 'top-center',
        autoClose: false,
        hideProgressBar: true,
        closeOnClick: false,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        theme: 'light',
        className: 'text-center maintenance-toast',
      });
      localStorage.setItem('maintenanceBannerId', toastId);
    }
  }, [maintenanceBanner.data]);

  const formRef = useCallback((node) => {
    if (node) {
      setFormElement(node);
    }
  }, []);

  // Handle sso login through parameter
  useEffect(() => {
    if (autoSignIn && currentUser.signed_in) { navigate('/', { replace: true }); }
    if (!env || !autoSignIn || !formElement) return;

    if (env.EXTERNAL_AUTH) {
      // eslint-disable-next-line no-unused-expressions
      formElement.requestSubmit?.() || formElement.submit();
    } else {
      navigate('/signin', { replace: true });
    }
  }, [autoSignIn, env, formElement]);

  // Pages that do not need a header: SignIn, SignUp and JoinMeeting (if the user is not signed in)
  const homePage = location.pathname === '/';
  const pageHeight = (homePage || currentUser.signed_in) ? 'regular-height' : 'no-header-height';

  // i18n
  const { i18n } = useTranslation();
  useEffect(() => {
    i18n.changeLanguage(currentUser?.language);
  }, [currentUser?.language]);

  // Greenlight V3 brand-color theming
  const { isLoading, data: brandColors } = useSiteSetting(['PrimaryColor', 'PrimaryColorLight']);

  if (isLoading) return null;

  document.documentElement.style.setProperty('--brand-color', brandColors.PrimaryColor);
  document.documentElement.style.setProperty('--brand-color-light', brandColors.PrimaryColorLight);
  document.documentElement.style.setProperty('--toastify-color-success', brandColors.PrimaryColor);

  return (
    <>
      <Title lang={currentUser?.language} dir={i18next.dir(currentUser?.language)}>BigBlueButton</Title>
      { autoSignIn
        ? (
          <Container fluid className="d-flex vh-100 justify-content-center align-items-center">
            <Spinner animation="border" role="status">
              <span className="visually-hidden">Signing you in…</span>
            </Spinner>

            <Form id="sso-form" ref={formRef} action={process.env.OMNIAUTH_PATH} method="POST" data-turbo="false" className="d-none">
              <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]').content} />
              <input type="hidden" name="current_provider" value={env?.CURRENT_PROVIDER} />
            </Form>
          </Container>
        ) : (
          <>
            {(homePage || currentUser.signed_in) && <Header />}
            <Container className={pageHeight}>
              <Outlet />
            </Container>
            <div ref={setToastAnchor} className="toast-anchor" />
            <ToastContainer
              className={toastsDocked ? 'toasts-docked' : undefined}
              position="bottom-right"
              newestOnTop
              autoClose={3000}
            />
            <Footer />
          </>
        )}
    </>
  );
}

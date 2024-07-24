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

import React, { useEffect } from 'react';
import { Container } from 'react-bootstrap';
import { Outlet, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { ToastContainer, toast } from 'react-toastify';
import Header from './components/shared_components/Header';
import { useAuth } from './contexts/auth/AuthProvider';
import Footer from './components/shared_components/Footer';
import useSiteSetting from './hooks/queries/site_settings/useSiteSetting';
import Title from './components/shared_components/utilities/Title';

export default function App() {
  const currentUser = useAuth();
  const location = useLocation();

  // check for the maintenance banner
  const maintenanceBanner = useSiteSetting(['Maintenance']);

  // useEffect hook for running notify maintenance banner on page load
  useEffect(() => {
    if (maintenanceBanner.data) {
      const toastId = toast.info(maintenanceBanner.data, {
        position: 'top-center',
        autoClose: false,
        hideProgressBar: true,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        theme: 'light',
        className: 'text-center',
      });
      localStorage.setItem('maintenanceBannerId', toastId);
    }
  }, [maintenanceBanner.data]);

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
      <Title>BigBlueButton</Title>
      {(homePage || currentUser.signed_in) && <Header /> }
      <Container className={pageHeight}>
        <Outlet />
      </Container>
      <ToastContainer
        position="bottom-right"
        newestOnTop
        autoClose={3000}
      />
      <Footer currentUser={currentUser} />
    </>
  );
}

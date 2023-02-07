import React, { useEffect } from 'react';
import { Container } from 'react-bootstrap';
import { Outlet, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { ToastContainer } from 'react-toastify';
import Header from './components/shared_components/Header';
import { useAuth } from './contexts/auth/AuthProvider';
import Footer from './components/shared_components/Footer';
import useSiteSetting from './hooks/queries/site_settings/useSiteSetting';

export default function App() {
  const currentUser = useAuth();
  const location = useLocation();

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
      {(homePage || currentUser.signed_in) && <Header /> }
      <Container className={pageHeight}>
        <Outlet />
      </Container>
      <ToastContainer
        position="bottom-right"
        newestOnTop
        autoClose={3000}
      />
      <Footer />
    </>
  );
}

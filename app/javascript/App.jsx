import React, { useEffect } from 'react';
import { Container } from 'react-bootstrap';
import { Outlet, useLocation } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import Header from './components/shared_components/Header';
import { useAuth } from './contexts/auth/AuthProvider';
import Footer from './components/shared_components/Footer';
import useSiteSetting from './hooks/queries/site_settings/useSiteSetting';

export default function App() {
  const currentUser = useAuth();
  const location = useLocation();

  // SignIn, SignUp and JoinMeeting pages do not need a Header
  const headerPage = location.pathname !== '/signin' && location.pathname !== '/signup' && !location.pathname.includes('/join');
  const pageHeight = headerPage ? 'regular-height' : 'no-header-height';

  // //i18n
  const { i18n } = useTranslation();
  useEffect(() => {
    i18n.changeLanguage(currentUser?.language);
  }, [currentUser?.language]);

  // Greenlight V3 brand-color theming
  const { isLoading, data: brandColors } = useSiteSetting(['PrimaryColor', 'PrimaryColorLight']);

  if (isLoading) return null;

  document.documentElement.style.setProperty('--brand-color', brandColors.PrimaryColor);
  document.documentElement.style.setProperty('--brand-color-light', brandColors.PrimaryColorLight);

  return (
    <>
      {headerPage && <Header /> }
      <Container className={pageHeight}>
        <Outlet />
      </Container>
      <Toaster
        position="bottom-right"
        toastOptions={{
          duration: 3000,
        }}
      />
      <Footer />
    </>
  );
}

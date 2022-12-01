import React, { useEffect } from 'react';
import { Container } from 'react-bootstrap';
import { Outlet, useLocation } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import Header from './components/shared_components/Header';
import { useAuth } from './contexts/auth/AuthProvider';
import Footer from './components/shared_components/Footer';
import useSiteSetting from './hooks/queries/site_settings/useSiteSetting';
import BackgroundBuffer from './components/shared_components/BackgroundBuffer';

export default function App() {
  const currentUser = useAuth();
  const location = useLocation();

  const pageHeight = () => {
    if (currentUser?.signed_in) {
      return 'regular-height';
    }

    // Need to double check for footer on homepage with Tyler
    if (location.pathname === '/') {
      return null;
    }

    return 'no-header-height';
  };

  // //i18n
  const { i18n } = useTranslation();
  useEffect(() => {
    i18n.changeLanguage(currentUser?.language);
  }, [currentUser?.language]);

  // Greenlight V3 brand-color theming
  const { isLoading, data: brandColor } = useSiteSetting('PrimaryColor');
  const { data: brandColorLight } = useSiteSetting('PrimaryColorLight');
  document.documentElement.style.setProperty('--brand-color', brandColor);
  document.documentElement.style.setProperty('--brand-color-light', brandColorLight);

  if (isLoading) return null;

  return (
    <>
      {currentUser?.signed_in && <Header /> }
      {currentUser?.verified && <BackgroundBuffer /> }
      <Container className={pageHeight()}>
        <Outlet />
      </Container>
      <Toaster
        position="bottom-right"
      />
      {(location.pathname !== '/') && <Footer />}
    </>
  );
}

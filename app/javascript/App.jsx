import React, { useEffect } from 'react';
import { Container } from 'react-bootstrap';
import { Outlet, useLocation } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import Header from './components/shared_components/Header';
import { useAuth } from './contexts/auth/AuthProvider';
import Footer from './components/shared_components/Footer';
import useSiteSetting from './hooks/queries/site_settings/useSiteSetting';
import useSiteSettings from "./hooks/queries/admin/site_settings/useSiteSettings";

export default function App() {
  const currentUser = useAuth();
  const pageHeight = currentUser?.signed_in ? 'regular-height' : 'no-header-height';
  const location = useLocation();

  // //i18n
  const { i18n } = useTranslation();
  useEffect(() => {
    i18n.changeLanguage(currentUser?.language);
  }, [currentUser?.language]);

  // Greenlight V3 brand-color theming
  const { isLoading, data: brandColors } = useSiteSettings(['PrimaryColor', 'PrimaryColorLight']);

  if (isLoading) return null;

  document.documentElement.style.setProperty('--brand-color', brandColors['PrimaryColor']);
  document.documentElement.style.setProperty('--brand-color-light', brandColors['PrimaryColorLight']);

  return (
    <>
      {location.pathname !== '/' && currentUser?.signed_in && <Header /> }
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

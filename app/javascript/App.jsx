import React from 'react';
import { Container, Spinner } from 'react-bootstrap';
import { Outlet } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import Header from './components/shared_components/Header';
import { useAuth } from './contexts/auth/AuthProvider';
import Footer from './components/shared_components/Footer';
import useSiteSettingAsync from './hooks/queries/site_settings/useSiteSettingAsync';

export default function App() {
  const currentUser = useAuth();
  const height = currentUser?.signed_in ? 'page-height' : 'homepage-height';

  // Greenlight V3 brand-color theming
  const { isLoading, data: brandColor } = useSiteSettingAsync('PrimaryColor');
  const { data: brandColorLight } = useSiteSettingAsync('PrimaryColorLight');

  document.documentElement.style.setProperty('--brand-color', brandColor);
  document.documentElement.style.setProperty('--brand-color-light', brandColorLight);

  if (isLoading) return <Spinner />;

  return (
    <>
      {currentUser?.signed_in && <Header /> }
      <Container className={height}>
        <Outlet />
      </Container>
      <Toaster
        position="bottom-right"
      />
      <Footer />
    </>
  );
}

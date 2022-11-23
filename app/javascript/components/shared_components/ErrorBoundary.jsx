import { isRouteErrorResponse, useRouteError } from 'react-router-dom';
import * as React from 'react';
import NotFoundPage from '../errors/NotFoundPage';
import DefaultErrorPage from '../errors/DefaultErrorPage';

export default function ErrorBoundary() {
  const error = useRouteError();

  if (isRouteErrorResponse(error)) {
    if (error.status === 404) {
      return (
        <NotFoundPage />
      );
    }
  }
  return <DefaultErrorPage />;
}

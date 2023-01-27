import React from 'react';
import { isRouteErrorResponse, useRouteError } from 'react-router-dom';
import DefaultErrorPage from './components/errors/DefaultErrorPage';
import NotFoundPage from './components/errors/NotFoundPage';

export default function RootBoundary() {
  const error = useRouteError();

  if (isRouteErrorResponse(error)) {
    // Route Errors
    switch (error.status) {
      case 404:
        return <NotFoundPage />;
      default:
        return <DefaultErrorPage />;
    }
  } else {
    // Non-Route Errors (hooks, promises, etc.)
    switch (error.response.status) {
      case 404:
        return <NotFoundPage />;
      default:
        return <DefaultErrorPage />;
    }
  }
}

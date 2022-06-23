import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import PropTypes from 'prop-types';

export default function ProtectedRoute({ when, redirectTo, children }) {
  if (!when) {
    return <Navigate to={redirectTo} replace />;
  }

  return children;
}

ProtectedRoute.defaultProps = {
  redirectTo: '/',
  children: <Outlet />,
};
ProtectedRoute.propTypes = {
  when: PropTypes.bool.isRequired,
  redirectTo: PropTypes.string,
  children: PropTypes.node,
};

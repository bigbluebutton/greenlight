import { Link } from 'react-router-dom';
import React from 'react';
import PropTypes from 'prop-types';

export default function HaveAnAccount({ haveAnAccount }) {
  if (haveAnAccount) {
    return (
      <span className="text-center text-muted small"> Don&apos;t have an account?
        <Link to="/signup" className="text-link"> Sign up </Link>
      </span>
    );
  }

  return (
    <span className="text-center text-muted small"> Already have an account?
      <Link to="/signin" className="text-link"> Sign In </Link>
    </span>
  );
}

HaveAnAccount.propTypes = {
  haveAnAccount: PropTypes.bool,
};

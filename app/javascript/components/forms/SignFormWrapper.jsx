import React from 'react';
import Card from 'react-bootstrap/Card';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import FormLogo from './FormLogo';

export default function SignFormWrapper({
  form, children,
}) {
  const linkTo = `/${form.link.toLowerCase().replaceAll(' ', '')}`;

  return (
    <>
      <FormLogo />
      <Card className="col-md-4 mx-auto p-4 border-0 shadow-sm">
        <Card.Title className="text-center pb-2"> {form.title} </Card.Title>
        {children}
        <span className="text-center text-muted small"> {form.haveAnAccount}
          <Link to={linkTo} className="text-link"> {form.link} </Link>
        </span>
      </Card>
    </>
  );
}

SignFormWrapper.propTypes = {
  form: PropTypes.shape(
    {
      title: PropTypes.string.isRequired,
      link: PropTypes.string.isRequired,
      haveAnAccount: PropTypes.string.isRequired,
    },
  ).isRequired,
  children: PropTypes.node.isRequired,
};

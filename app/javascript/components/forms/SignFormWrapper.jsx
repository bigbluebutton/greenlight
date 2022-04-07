import React from 'react';
import Card from 'react-bootstrap/Card';
import PropTypes from 'prop-types';
import FormLogo from './FormLogo';
import HaveAnAccount from './HaveAnAccount';

export default function SignFormWrapper({ title, children, haveAnAccount }) {
  return (
    <>
      <FormLogo />
      <Card className="col-md-4 mx-auto p-4 border-0 shadow-sm">
        <Card.Title className="text-center pb-2"> {title} </Card.Title>
        { children }
        <HaveAnAccount haveAnAccount={haveAnAccount} />
      </Card>
    </>
  );
}

SignFormWrapper.propTypes = {
  title: PropTypes.string.isRequired,
  children: PropTypes.node.isRequired,
  haveAnAccount: PropTypes.bool,
};

// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

/* eslint-disable react/jsx-props-no-spreading */

import React from 'react';
import { FormProvider } from 'react-hook-form';
import { Form as BootStrapForm } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function Form({
  methods, children, onSubmit, ...props
}) {
  return (
    <FormProvider {...methods}>
      <BootStrapForm {...props} noValidate onSubmit={(e) => { e.stopPropagation(); methods.handleSubmit(onSubmit)(e); }}>
        {children}
      </BootStrapForm>
    </FormProvider>
  );
}

Form.defaultProps = {
  onSubmit: () => { },
  onBlur: () => { },
  onChange: () => { },
};

Form.propTypes = {
  methods: PropTypes.shape(
    {
      reset: PropTypes.func.isRequired,
      handleSubmit: PropTypes.func.isRequired,
      formState: PropTypes.shape({
        isSubmitted: PropTypes.bool.isRequired,
        isSubmitting: PropTypes.bool.isRequired,
        isValid: PropTypes.bool.isRequired,
      }).isRequired,
    },
  ).isRequired,
  children: PropTypes.node.isRequired,
  onSubmit: PropTypes.func,
  onBlur: PropTypes.func,
  onChange: PropTypes.func,
};

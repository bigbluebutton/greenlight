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
import { Form as BootStrapForm } from 'react-bootstrap';
import { useFormContext } from 'react-hook-form';
import PropTypes from 'prop-types';

export default function FormControlGeneric({
  field, control: Control, children, ...props
}) {
  const { register, formState: { errors } } = useFormContext();
  const { hookForm } = field;
  const { id, validations } = hookForm;
  const error = errors[id];

  return (
    <Control {...props} placeholder={field.placeHolder} isInvalid={error} {...register(id, validations)}>
      {children}
    </Control>
  );
}

FormControlGeneric.defaultProps = {
  control: BootStrapForm.Control,
  children: null,
};

FormControlGeneric.propTypes = {
  field: PropTypes.shape(
    {
      label: PropTypes.string,
      placeHolder: PropTypes.string,
      controlId: PropTypes.string,
      hookForm: PropTypes.shape(
        {
          id: PropTypes.string.isRequired,
          validations: PropTypes.shape({
            deps: PropTypes.arrayOf(PropTypes.string),
          }),
        },
      ).isRequired,
    },
  ).isRequired,
  control: PropTypes.shape({}),
  children: PropTypes.node,
};

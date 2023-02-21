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
import { useTranslation } from 'react-i18next';
import FormControlGeneric from './FormControlGeneric';

export default function FormControl({
  field, control, children, noLabel, ...props
}) {
  const { t } = useTranslation();

  const { formState: { errors } } = useFormContext();
  const error = errors[field.hookForm.id];

  return (
    <BootStrapForm.Group className="mb-2" controlId={field.controlId}>
      {
        !noLabel
        && (
          <BootStrapForm.Label className="small mb-0">
            {field.label}
          </BootStrapForm.Label>
        )
      }
      <FormControlGeneric {...props} field={field} control={control}>
        {children}
      </FormControlGeneric>
      {
        error
        && (
          (error.types
            && Object.keys(error.types).map(
              (key) => (
                error.types[key] && <BootStrapForm.Control.Feedback key={key} type="invalid">{t(error.types[key])}</BootStrapForm.Control.Feedback>
              ),
            )
          )
          || (error.message && <BootStrapForm.Control.Feedback type="invalid">{t(error.message)}</BootStrapForm.Control.Feedback>)
        )

      }
    </BootStrapForm.Group>
  );
}

FormControl.defaultProps = {
  noLabel: false,
  control: undefined,
  children: undefined,
};

FormControl.propTypes = {
  field: PropTypes.shape(
    {
      label: PropTypes.string,
      placeHolder: PropTypes.string,
      controlId: PropTypes.string.isRequired,
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
  noLabel: PropTypes.bool,
  control: PropTypes.shape({}),
  children: PropTypes.node,
};

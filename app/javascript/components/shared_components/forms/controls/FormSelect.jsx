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

import React from 'react';
import PropTypes from 'prop-types';
import { Form as BootStrapForm } from 'react-bootstrap';
import { useController } from 'react-hook-form';
import Select from '../../utilities/Select';

export default function FormSelect({
  children, variant, field,
}) {
  const { hookForm: { id: name, validations: rules } } = field;

  const {
    field: { onChange, onBlur, value },
    fieldState: { invalid, error },
  } = useController({
    name,
    rules,
  });

  return (
    <BootStrapForm.Group className="mb-2" controlId={field.controlId}>
      <BootStrapForm.Label className="small mb-0">
        {field.label}
      </BootStrapForm.Label>
      <Select
        id={field.controlId}
        onChange={onChange}
        onBlur={onBlur}
        value={value}
        variant={variant}
        isValid={!invalid}
      >
        { children }
      </Select>
      {
        error
        && (
          (error.types
            && Object.keys(error.types).map(
              (key) => (
                error.types[key] && <BootStrapForm.Control.Feedback key={key} type="invalid">{error.types[key]}</BootStrapForm.Control.Feedback>
              ),
            )
          )
          || (error.message && <BootStrapForm.Control.Feedback type="invalid">{error.message}</BootStrapForm.Control.Feedback>)
        )

      }
    </BootStrapForm.Group>
  );
}

FormSelect.defaultProps = {
  variant: undefined,
};

FormSelect.propTypes = {
  children: PropTypes.arrayOf(PropTypes.element).isRequired,
  variant: PropTypes.string,
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
};

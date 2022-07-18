/* eslint-disable react/jsx-props-no-spreading */

import React from 'react';
import PropTypes from 'prop-types';
import { TrashIcon } from '@heroicons/react/outline';
import { RegistrationFormFields } from '../../../helpers/forms/RegistrationFormHelpers';
import FormControl from '../FormControl';

export default function RegistrationRow({ index, remove, errors }) {
  return (
    <tr>
      <td className="fw-normal border-end-0">
        <FormControl
          fieldError={errors && errors[index]?.name}
          field={RegistrationFormFields(index).name}
          type="text"
          noLabel
        />
      </td>
      <td className="fw-normal border-0">
        <FormControl
          fieldError={errors && errors[index]?.suffix}
          field={RegistrationFormFields(index).suffix}
          type="text"
          noLabel
        />
      </td>
      <td className="border-start-0">
        <TrashIcon className="cursor-pointer hi-s text-danger ms-4 me-0" onClick={() => remove(index)} />
      </td>
    </tr>
  );
}

RegistrationRow.defaultProps = {
  errors: [],
};

RegistrationRow.propTypes = {
  index: PropTypes.number.isRequired,
  remove: PropTypes.func.isRequired,
  errors: PropTypes.arrayOf(
    PropTypes.shape({
      name: PropTypes.shape({ message: PropTypes.string }),
      suffix: PropTypes.shape({ message: PropTypes.string }),
    }),
  ),
};

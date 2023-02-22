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

import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { useCallback, useMemo } from 'react';

export function useSignUpFormValidation() {
  return useMemo(() => (yup.object({
    name: yup.string().required('forms.validations.full_name.required')
      .min(2, 'forms.validations.full_name.min')
      .max(255, 'forms.validations.full_name.max'),

    email: yup.string().required('forms.validations.email.required').email('forms.validations.email.email')
      .min(6, 'forms.validations.email.min')
      .max(255, 'forms.validations.email.max'),

    password: yup.string().max(255, 'forms.validations.password.max')
      .matches(
        /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[`@%~!#£$\\^&*()\][+={}/|:;"'<>\-,.?_ ]).{8,}$/,
        'forms.validations.password.match',
      )
      .min(8, 'forms.validations.password.min')
      .test('oneLower', 'forms.validations.password.lower', (pwd) => pwd.match(/[a-z]/))
      .test('oneUpper', 'forms.validations.password.upper', (pwd) => pwd.match(/[A-Z]/))
      .test('oneDigit', 'forms.validations.password.digit', (pwd) => pwd.match(/\d/))
      .test('oneSymbol', 'forms.validations.password.symbol', (pwd) => pwd.match(/[`@%~!#£$\\^&*()\][+={}/|:;"'<>\-,.?_ ]/)),
    password_confirmation: yup.string().required('forms.validations.password_confirmation.required')
      .oneOf([yup.ref('password')], 'forms.validations.password_confirmation.match'),
  })), []);
}

export default function useSignUpForm({ defaultValues: _defaultValues, ..._config } = {}) {
  const { t, i18n } = useTranslation();

  const fields = useMemo(() => ({
    name: {
      label: t('forms.user.signup.fields.full_name.label'),
      placeHolder: t('forms.user.signup.fields.full_name.placeholder'),
      controlId: 'signupFormFullName',
      hookForm: {
        id: 'name',
      },
    },
    email: {
      label: t('forms.user.signup.fields.email.label'),
      placeHolder: t('forms.user.signup.fields.email.placeholder'),
      controlId: 'signupFormEmail',
      hookForm: {
        id: 'email',
      },
    },
    password: {
      label: t('forms.user.signup.fields.password.label'),
      placeHolder: t('forms.user.signup.fields.password.placeholder'),
      controlId: 'signupFormPwd',
      hookForm: {
        id: 'password',
        validations: {
          deps: ['password_confirmation'],
        },
      },
    },
    password_confirmation: {
      label: t('forms.user.signup.fields.password_confirmation.label'),
      placeHolder: t('forms.user.signup.fields.password_confirmation.placeholder'),
      controlId: 'signupFormPwdConfirm',
      hookForm: {
        id: 'password_confirmation',
        validations: {
          deps: ['password'],
        },
      },
    },
  }), [i18n.resolvedLanguage]);

  const validationSchema = useSignUpFormValidation();

  const config = useMemo(() => ({
    ...{
      mode: 'onChange',
      criteriaMode: 'all',
      defaultValues: {
        ...{
          name: '',
          email: '',
          password: '',
          password_confirmation: '',
        },
        ..._defaultValues,
      },
      resolver: yupResolver(validationSchema),
    },
    ..._config,
  }), [validationSchema, _defaultValues]);

  const methods = useForm(config);

  const reset = useCallback(() => methods.reset(config.defaultValues), [methods.reset, config.defaultValues]);

  return { methods, fields, reset };
}

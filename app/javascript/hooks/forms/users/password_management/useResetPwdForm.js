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

export function useResetPwdFormValidation() {
  return useMemo(() => (yup.object({
    new_password: yup.string().max(255, 'forms.validations.password.max')
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
      .oneOf([yup.ref('new_password')], 'forms.validations.password_confirmation.match'),
  })), []);
}

export default function useResetPwdForm({ defaultValues: _defaultValues, ..._config } = {}) {
  const { t, i18n } = useTranslation();

  const fields = useMemo(() => ({
    new_password: {
      label: t('forms.user.reset_password.fields.new_password.label'),
      placeHolder: t('forms.user.reset_password.fields.new_password.placeholder'),
      controlId: 'resetPwdFormNewPwd',
      hookForm: {
        id: 'new_password',
        validations: {
          deps: ['password_confirmation'],
        },
      },
    },
    password_confirmation: {
      label: t('forms.user.reset_password.fields.password_confirmation.label'),
      placeHolder: t('forms.user.reset_password.fields.password_confirmation.placeholder'),
      controlId: 'resetPwdFormPwdConfirm',
      hookForm: {
        id: 'password_confirmation',
        validations: {
          deps: ['new_password'],
        },
      },
    },
  }), [i18n.resolvedLanguage]);

  const validationSchema = useResetPwdFormValidation();

  const config = useMemo(() => ({
    ...{
      mode: 'onChange',
      criteriaMode: 'all',
      defaultValues: {
        ...{
          new_password: '',
          password_confirmation: '',
          token: '',
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

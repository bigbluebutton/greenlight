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

import { useMemo } from 'react';
import { yupResolver } from '@hookform/resolvers/yup';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { useSignUpFormValidation } from '../../users/authentication/useSignUpForm';

export default function useUserSignupForm({ defaultValues: _defaultValues, ..._config } = {}) {
  const { t, i18n } = useTranslation();

  const fields = useMemo(() => ({
    name: {
      label: t('forms.admin.createUser.fields.full_name.label'),
      placeHolder: t('forms.admin.createUser.fields.full_name.placeholder'),
      controlId: 'createUserFormFullName',
      hookForm: {
        id: 'name',
      },
    },
    email: {
      label: t('forms.admin.createUser.fields.email.label'),
      placeHolder: t('forms.admin.createUser.fields.email.placeholder'),
      controlId: 'createUserFormEmail',
      hookForm: {
        id: 'email',
      },
    },
    password: {
      label: t('forms.admin.createUser.fields.password.label'),
      placeHolder: t('forms.admin.createUser.fields.password.placeholder'),
      controlId: 'createUserFormPwd',
      hookForm: {
        id: 'password',
        validations: {
          deps: ['password_confirmation'],
        },
      },
    },
    password_confirmation: {
      label: t('forms.admin.createUser.fields.password_confirmation.label'),
      placeHolder: t('forms.admin.createUser.fields.password_confirmation.placeholder'),
      controlId: 'createUserFormPwdConfirm',
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

  return { methods: useForm({ ...config, ..._config }), fields };
}

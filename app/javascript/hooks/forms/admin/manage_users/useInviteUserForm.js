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

export function useInviteUserFormValidation() {
  return useMemo(() => (yup.object({
    emails: yup.string()
      .required('forms.validations.emails.required')
      .test(
        'emails',
        'forms.validations.emails.list',
        (emails) => emails.split(',').every((email) => yup.string().required().email().isValidSync(email)),
      ),
  })), []);
}

export default function useInviteUserForm({ defaultValues: _defaultValues, ..._config } = {}) {
  const { t, i18n } = useTranslation();

  const fields = useMemo(() => ({
    emails: {
      label: t('forms.admin.invite_user.fields.emails.label'),
      placeHolder: 'user1@users.com,user2@users.com,user3@users.com',
      controlId: 'createInvitationFormEmails',
      hookForm: {
        id: 'emails',
      },
    },
  }), [i18n.resolvedLanguage]);

  const validationSchema = useInviteUserFormValidation();

  const config = useMemo(() => ({
    ...{
      mode: 'onChange',
      criteriaMode: 'firstError',
      defaultValues: {
        ...{
          emails: '',
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

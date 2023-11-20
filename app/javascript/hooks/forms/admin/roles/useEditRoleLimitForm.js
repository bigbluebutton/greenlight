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

export function useEditRoleLimitFormValidation() {
  return useMemo(() => (yup.object({
    value: yup.number().required('forms.validations.role.limit.required')
      .typeError('forms.validations.role.type.error')
      .min(0, 'forms.validations.role.limit.min')
      .max(10000, 'forms.validations.role.limit.max'),
  })), []);
}

export default function useEditRoleLimitForm({ defaultValues: _defaultValues, ..._config } = {}) {
  const { t, i18n } = useTranslation();

  const fields = useMemo(() => ({
    value: {
      label: t('forms.admin.roles.fields.value.label'),
      placeHolder: t('forms.admin.roles.fields.value.placeholder'),
      controlId: 'editRoleRoomLimit',
      hookForm: {
        id: 'value',
      },
    },
  }), [i18n.resolvedLanguage]);

  const validationSchema = useEditRoleLimitFormValidation();

  const config = useMemo(() => ({
    ...{
      mode: 'onChange',
      defaultValues: {
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

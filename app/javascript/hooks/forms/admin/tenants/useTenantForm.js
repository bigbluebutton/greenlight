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

export function useTenantFormValidation() {
  return useMemo(() => (yup.object({
    name: yup.string().required('Field is required'),
    client_secret: yup.string().required('Field is required'),
    region: yup.string().required('Field is required'),
  })), []);
}

export default function useTenantForm({ defaultValues: _defaultValues, ..._config } = {}) {
  const { i18n } = useTranslation();

  const fields = useMemo(() => ({
    name: {
      label: 'Name',
      placeHolder: 'Enter a name...',
      controlId: 'createTenantFormName',
      hookForm: {
        id: 'name',
      },
    },
    client_secret: {
      label: 'Keycloak Client Secret',
      placeHolder: 'Keycloak Client Secret',
      controlId: 'createTenantFormClientSecret',
      hookForm: {
        id: 'client_secret',
      },
    },
    region: {
      label: 'Region',
      placeHolder: 'rna1',
      controlId: 'createTenantFormRegion',
      hookForm: {
        id: 'region',
      },
    },
  }), [i18n.resolvedLanguage]);

  const validationSchema = useTenantFormValidation();

  const config = useMemo(() => ({
    ...{
      mode: 'onChange',
      defaultValues: {
        ...{
          name: '',
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

import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { useCallback, useMemo } from 'react';

export function useInviteUserFormValidation() {
  return useMemo(() => (yup.object({
    emails: yup.string(),
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

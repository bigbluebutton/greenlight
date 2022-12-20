import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';

export default function useSignUpForm(_config = {}) {
  const { t } = useTranslation();

  const fields = {
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
  };

  const validationSchema = yup.object({
    name: yup.string().required('forms.user.signup.validations.full_name.required')
      .min(2, 'forms.user.signup.validations.full_name.min')
      .max(255, 'forms.user.signup.validations.full_name.max'),

    email: yup.string().required('forms.user.signup.validations.email.required').email('forms.user.signup.validations.email.email')
      .min(6, 'forms.user.signup.validations.email.min')
      .max(255, 'forms.user.signup.validations.email.max'),

    password: yup.string().max(255, 'forms.user.signup.validations.password.max')
      .matches(
        /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[`@%~!#£$\\^&*()\][+={}/|:;"'<>\-,.?_ ]).{8,}$/,
        'forms.user.signup.validations.password.match',
      )
      .min(8, 'forms.user.signup.validations.password.min')
      .test('oneLower', 'forms.user.signup.validations.password.lower', (pwd) => pwd.match(/[a-z]/))
      .test('oneUpper', 'forms.user.signup.validations.password.upper', (pwd) => pwd.match(/[A-Z]/))
      .test('oneDigit', 'forms.user.signup.validations.password.digit', (pwd) => pwd.match(/\d/))
      .test('oneSymbol', 'forms.user.signup.validations.password.symbol', (pwd) => pwd.match(/[`@%~!#£$\\^&*()\][+={}/|:;"'<>\-,.?_ ]/)),
    password_confirmation: yup.string().required('forms.user.signup.validations.password_confirmation.required')
      .oneOf([yup.ref('password')], 'forms.user.signup.validations.password_confirmation.match'),
  });

  const config = {
    mode: 'onChange',
    criteriaMode: 'all',
    defaultValues: {
      name: '',
      email: '',
      password: '',
      password_confirmation: '',
    },
    resolver: yupResolver(validationSchema),
  };

  return { methods: useForm({ ...config, ..._config }), fields };
}

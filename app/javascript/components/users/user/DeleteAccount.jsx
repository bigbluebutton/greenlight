import React from 'react';
import { Button } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import Modal from '../../shared_components/modals/Modal';
import DeleteUserForm from './forms/DeleteUserForm';

export default function DeleteAccount() {
  const { t } = useTranslation();

  return (
    <div id="delete-account">
      <h3 className="mb-4"> { t('user.account.permanently_delete_account') } </h3>
      <p className="text-muted pb-2">
        { t('user.account.delete_account_description') }
      </p>
      <Modal
        modalButton={<Button variant="delete">{ t('user.account.delete_account_confirmation') }</Button>}
        title={t('are_you_sure')}
        body={<DeleteUserForm />}
      />
    </div>
  );
}

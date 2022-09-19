import React from 'react';
import { Col, Row } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import SetAvatar from './SetAvatar';
import UpdateUserForm from './forms/UpdateUserForm';

export default function AccountInfo({ user }) {
  const { t } = useTranslation();

  return (
    <Row>
      <Col>
        <h3 className="mb-4"> { t('user.account.update_account_info') } </h3>
        <UpdateUserForm user={user} />
      </Col>
      <Col>
        <SetAvatar user={user} />
      </Col>
    </Row>
  );
}

AccountInfo.propTypes = {
  user: PropTypes.shape({
    id: PropTypes.string.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string.isRequired,
    provider: PropTypes.string.isRequired,
    role: PropTypes.shape({
      id: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired,
      color: PropTypes.string.isRequired,
    }).isRequired,
  }).isRequired,
};

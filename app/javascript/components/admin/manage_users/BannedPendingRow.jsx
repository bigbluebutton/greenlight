import React from 'react';
import PropTypes from 'prop-types';
import {
  Stack, Navbar, Container,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import Avatar from '../../users/user/Avatar';

export default function BannedPendingRow({ user, children }) {
  const { t } = useTranslation();

  return (
    <tr key={user.id} className="align-middle text-muted">
      <td className="text-dark border-end-0">
        <Stack direction="horizontal">
          <div className="me-2">
            <Avatar avatar={user.avatar} radius={40} />
          </div>
          <Stack>
            <strong> {user.name} </strong>
            <span className="small text-muted"> { t('admin.manage_users.user_created_at', { user }) }</span>
          </Stack>
        </Stack>
      </td>

      <td className="border-0"> {user.email} </td>
      <td className="border-0"> {user.created_at} </td>
      <td className="border-start-0">
        <Navbar>
          <Container>
            <div className="d-inline-flex">
              {children}
            </div>
          </Container>
        </Navbar>
      </td>
    </tr>
  );
}

BannedPendingRow.propTypes = {
  user: PropTypes.shape({
    id: PropTypes.string.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string.isRequired,
    created_at: PropTypes.string.isRequired,
  }).isRequired,
  children: PropTypes.node.isRequired,
};

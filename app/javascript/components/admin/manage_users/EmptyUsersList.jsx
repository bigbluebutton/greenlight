import React from 'react';
import { Card } from 'react-bootstrap';
// import { useTranslation } from 'react-i18next';
import { UsersIcon } from '@heroicons/react/24/outline';
import PropTypes from 'prop-types';

export default function EmptyUsersList({ text }) {
  // const { t } = useTranslation();

  return (
    <div id="list-empty">
      <Card className="border-0 text-center">
        <Card.Body className="py-5">
          <div className="icon-circle rounded-circle d-block mx-auto mb-3">
            <UsersIcon className="hi-l text-brand d-block mx-auto" />
          </div>
          <Card.Title className="text-brand"> {`There are no ${text} users on this server yet!`}</Card.Title>
          <Card.Text>
            {`When a user's status gets changed to ${text}, they will appear here.`}
          </Card.Text>
        </Card.Body>
      </Card>
    </div>
  );
}

EmptyUsersList.propTypes = {
  text: PropTypes.string.isRequired,
};

import React from 'react';
import { Card } from 'react-bootstrap';
import { UsersIcon } from '@heroicons/react/24/outline';
import PropTypes from 'prop-types';

export default function EmptyUsersList({ text, subtext }) {
  return (
    <div id="list-empty">
      <Card className="border-0 text-center">
        <Card.Body className="py-5">
          <div className="icon-circle rounded-circle d-block mx-auto mb-3">
            <UsersIcon className="hi-l text-brand d-block mx-auto" />
          </div>
          <Card.Title className="text-brand"> {text}</Card.Title>
          <Card.Text>
            {subtext}
          </Card.Text>
        </Card.Body>
      </Card>
    </div>
  );
}

EmptyUsersList.propTypes = {
  text: PropTypes.string.isRequired,
  subtext: PropTypes.string.isRequired,
};

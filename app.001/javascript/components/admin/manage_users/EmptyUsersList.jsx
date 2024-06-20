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

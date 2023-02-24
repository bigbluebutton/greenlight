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
import PropTypes from 'prop-types';

export default function HomepageFeatureCard({ title, description, icon }) {
  return (
    <Card className="homepage-card h-100 card-shadow border-0">
      <Card.Body className="p-4">
        <div className="homepage-card-icon-circle rounded-circle mb-4 d-flex align-items-center justify-content-center">
          { icon }
        </div>
        <Card.Title className="pt-2"> { title } </Card.Title>
        <Card.Text className="text-muted"> { description } </Card.Text>
      </Card.Body>
    </Card>
  );
}

HomepageFeatureCard.propTypes = {
  title: PropTypes.string.isRequired,
  description: PropTypes.string.isRequired,
  icon: PropTypes.element.isRequired,
};

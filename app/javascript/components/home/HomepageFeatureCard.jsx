import React from 'react';
import { Card } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function HomepageFeatureCard({ title, description, icon }) {
  return (
    <Card className="homepage-card h-100 shadow-sm border-0">
      <Card.Body className="p-4">
        <div className="homepage-card-icon-circle rounded-circle mb-5 d-flex align-items-center justify-content-center">
          { icon }
        </div>
        <Card.Title> { title } </Card.Title>
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




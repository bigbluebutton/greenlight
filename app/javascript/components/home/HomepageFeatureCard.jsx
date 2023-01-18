import React from 'react';
import { Card } from 'react-bootstrap';

export default function HomepageFeatureCard({title, description, icon }) {
  return (
    <Card id="homepage-feature-card" className="h-100 shadow-sm border-0">
      <Card.Body className="pb-0">
        { icon }
        <Card.Title> { title } </Card.Title>
        <p className="text-muted"> { description } </p>
      </Card.Body>
    </Card>
  );
}

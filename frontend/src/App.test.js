import React from 'react';
import { render, screen } from '@testing-library/react';
import App from './App';

// Mock the API service
jest.mock('./services/api', () => ({
  setAuthToken: jest.fn(),
  get: jest.fn(),
  post: jest.fn(),
  put: jest.fn(),
  delete: jest.fn(),
}));

describe('App Component', () => {
  test('renders task manager title', () => {
    render(<App />);
    const titleElement = screen.getByText(/task manager/i);
    expect(titleElement).toBeInTheDocument();
  });

  test('renders login form initially', () => {
    render(<App />);
    const loginElement = screen.getByText(/login/i);
    expect(loginElement).toBeInTheDocument();
  });

  test('has register link', () => {
    render(<App />);
    const registerLink = screen.getByText(/register/i);
    expect(registerLink).toBeInTheDocument();
  });
});

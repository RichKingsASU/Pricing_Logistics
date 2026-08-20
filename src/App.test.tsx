import { render, act } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import App from './App';

describe('App', () => {
  it('renders without crashing', async () => {
    let container: HTMLElement;
    await act(async () => {
      const result = render(<App />);
      container = result.container;
    });
    expect(container!).toBeInTheDocument();
  });
});

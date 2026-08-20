import { describe, it, expect } from 'vitest';
import { sanitizeSpreadsheetCell } from './spreadsheetSanitizer';

describe('sanitizeSpreadsheetCell', () => {
  it('protects =SUM(A1:A2)', () => {
    expect(sanitizeSpreadsheetCell('=SUM(A1:A2)')).toBe("'=SUM(A1:A2)");
  });
  it('protects +cmd', () => {
    expect(sanitizeSpreadsheetCell('+cmd')).toBe("'+cmd");
  });
  it('protects -1+2 when represented as a string', () => {
    expect(sanitizeSpreadsheetCell('-1+2')).toBe("'-1+2");
  });
  it('protects @SUM(A1:A2)', () => {
    expect(sanitizeSpreadsheetCell('@SUM(A1:A2)')).toBe("'@SUM(A1:A2)");
  });
  it('protects leading whitespace followed by =', () => {
    expect(sanitizeSpreadsheetCell('  =SUM(A1:A2)')).toBe("'  =SUM(A1:A2)");
  });
  it('protects tab followed by =', () => {
    expect(sanitizeSpreadsheetCell('\t=SUM')).toBe("'\t=SUM");
  });
  it('protects carriage return/newline followed by =', () => {
    expect(sanitizeSpreadsheetCell('\n=SUM')).toBe("'\n=SUM");
    expect(sanitizeSpreadsheetCell('\r\n=SUM')).toBe("'\r\n=SUM");
  });
  it('allows safe ordinary text', () => {
    expect(sanitizeSpreadsheetCell('Oakland, CA')).toBe('Oakland, CA');
  });
  it('allows safe email-like text where @ is not the first meaningful character', () => {
    expect(sanitizeSpreadsheetCell('user@example.com')).toBe('user@example.com');
  });
  it('leaves numbers as numbers', () => {
    expect(sanitizeSpreadsheetCell(42)).toBe(42);
    expect(sanitizeSpreadsheetCell(0)).toBe(0);
    expect(sanitizeSpreadsheetCell(-5.5)).toBe(-5.5);
  });
  it('leaves booleans as booleans', () => {
    expect(sanitizeSpreadsheetCell(true)).toBe(true);
    expect(sanitizeSpreadsheetCell(false)).toBe(false);
  });
  it('handles null/undefined correctly', () => {
    expect(sanitizeSpreadsheetCell(null)).toBeNull();
    expect(sanitizeSpreadsheetCell(undefined)).toBeUndefined();
  });
});

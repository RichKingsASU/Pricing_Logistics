export function sanitizeSpreadsheetCell(value: any): any {
  if (typeof value !== 'string') return value;
  if (!value) return value;
  
  const trimmed = value.trimStart();
  if (!trimmed) return value; // only whitespace

  const firstChar = trimmed[0];
  if (['=', '+', '-', '@'].includes(firstChar)) {
    return "'" + value;
  }
  return value;
}

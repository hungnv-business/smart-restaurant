import { VndCurrencyPipe } from './vnd-currency.pipe';

describe('VndCurrencyPipe', () => {
  let pipe: VndCurrencyPipe;

  beforeEach(() => {
    pipe = new VndCurrencyPipe();
  });

  it('should create an instance', () => {
    expect(pipe).toBeTruthy();
  });

  it('should handle null values', () => {
    expect(pipe.transform(null)).toBe('Chưa có giá');
    expect(pipe.transform(undefined)).toBe('Chưa có giá');
  });

  it('should handle zero values', () => {
    expect(pipe.transform(0)).toBe('0 ₫');
    expect(pipe.transform(0, false)).toBe('0');
  });

  it('should format Vietnamese currency correctly', () => {
    expect(pipe.transform(1000)).toBe('1.000 ₫');
    expect(pipe.transform(10000)).toBe('10.000 ₫');
    expect(pipe.transform(100000)).toBe('100.000 ₫');
    expect(pipe.transform(1000000)).toBe('1.000.000 ₫');
  });

  it('should format without symbol when requested', () => {
    expect(pipe.transform(1000, false)).toBe('1.000');
    expect(pipe.transform(10000, false)).toBe('10.000');
  });

  it('should handle decimal numbers by rounding', () => {
    expect(pipe.transform(1000.99)).toBe('1.001 ₫');
    expect(pipe.transform(1000.49)).toBe('1.000 ₫');
  });
});
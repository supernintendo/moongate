import { Environment } from './Environment';

interface HtmlEntities {
  '&': string;
  '<': string;
  '>': string;
  '"': string;
  '\'': string;
  '/': string;
  '`': string;
  '=': string;
  [key: string]: string;
}
const htmlEntities : HtmlEntities = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  '\'': '&#39;',
  '/': '&#x2F;',
  '`': '&#x60;',
  '=': '&#x3D;'
}

export class Utility {
  static camelize(input: string) {
    return input.replace(/(\_\w)/g, (m) => m[1].toUpperCase());
  }
  static capitalize(input: string) {
    return input.charAt(0).toUpperCase() + input.slice(1);
  }
  static escapeHtml(input: string) {
    return String(input).replace(/[&<>"'`=\/]/g, function (chunk: string) {
      return htmlEntities[chunk];
    });
  }
  static numberToHex(number: number, padding: number) {
    return (number + Math.pow(16, padding)).toString(16).slice(-padding).toUpperCase();
  }
}

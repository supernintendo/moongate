import { Ring } from './Ring'
import { RingLink } from './RingLink'

export class RingMember {
  _: Ring
  attributes: any
  links: Array<RingLink>
  isNew: boolean
  constructor(attributes: any, context: Ring) {
    this._ = context;
    this.attributes = attributes;
    this.isNew = true;
  }
  index() {
    return this.attributes.__index__;
  }
  setAttribute(key : string, value : any) {
    this.attributes[key] = value;
    this.isNew = false;
  }
  morphed() {
    let index = this.index(),
        result = this.attributes,
        keys = Object.keys(this.attributes),
        now = new Date();

    for (let i = 0, l = keys.length; i !== l; i++) {
      let ruleKeys = Object.keys(this._.morphs);

      for (let j = 0, k = ruleKeys.length; j !== k; j++) {
        let morph = this._.morphs[ruleKeys[j]];

        if (morph[keys[i]] && morph[keys[i]].morphs && morph[keys[i]].morphs[index]) {
          let memberMorph = morph[keys[i]].morphs[index],
              delta = (now.getTime() - memberMorph.startedAt) * memberMorph.amount / memberMorph.interval;

          result[keys[i]] = result[keys[i]] + delta;
        }
      }
    }
    return result;
  }
}

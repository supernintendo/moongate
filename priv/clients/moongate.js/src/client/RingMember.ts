import { Ring } from "./Ring"
import { Utility } from "../common/Utility"

export class RingMember {
  attributes: any
  droppedHandler: Function
  isNew: boolean
  isVoid: boolean
  parent: Ring
  constructor(attributes: any, parent: Ring, isVoid: Boolean) {
    this.parent = parent;
    this.attributes = attributes;
    isVoid ? (this.isVoid = true) : (this.isNew = true);

    return this;
  }
  index() {
    return this.attributes.__index__;
  }
  onDropped(callback: Function) {
    this.droppedHandler = callback;
  }
  setAttribute(key: string, value : any) {
    this.attributes[key] = value;
    this.isNew = false;
  }
  freezeMorph(key: string, rule: string, index: number) {
    let morph = this.parent.morphs[rule];

    if (morph) {
      this.attributes[key] = this.morphedValue(
        this.attributes[key],
        morph[key].morphs[index]
      );
    }
  }
  morphed() {
    let index = this.index(),
        attributes = this.attributes,
        result: any = {},
        keys = Object.keys(attributes);

    for (let i = 0, l = keys.length; i !== l; i++) {
      let key = keys[i],
          ruleKeys = Object.keys(this.parent.morphs);

      result[key] = attributes[key];

      for (let j = 0, k = ruleKeys.length; j !== k; j++) {
        let morph = this.parent.morphs[ruleKeys[j]];
        (
          morph[key]
          && morph[key].morphs
          && morph[key].morphs[index]
          && (result[key] = this.morphedValue(
              attributes[key],
              morph[key].morphs[index]
            )
          )
        );
      }
    }
    return result;
  }
  morphedValue(value: any, tween: any) {
    return Utility.morphedValue(
      value,
      tween,
      this.parent.atlas.startTime
    );
  }
}

export const platformToRouting = {
  na1: 'americas', br1: 'americas', la1: 'americas', la2: 'americas',
  eun1: 'europe', euw1: 'europe', tr1: 'europe', ru: 'europe',
  kr: 'asia', jp1: 'asia',
  oc1: 'sea', ph2: 'sea', sg2: 'sea', th2: 'sea', tw2: 'sea', vn2: 'sea',
};
export const validRouting = new Set(['americas', 'europe', 'asia', 'sea']);
export const validPlatforms = new Set(Object.keys(platformToRouting));

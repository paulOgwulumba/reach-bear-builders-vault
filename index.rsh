'reach 0.1';

export const main = Reach.App(() => {
  const DEADLINE = 120;

  const [isOutcome, CONTINUE, TERMINATE] = makeEnum(2);

  const shared = {
    viewCountdown: Fun([UInt], Null),
    informTimeout: Fun([], Null),
    getUpdate: Fun([Bool], Null),
  }
  const A = Participant('Alice', {
    flickSwitch: Fun([], Bool),
    ...shared,
  });

  const B = Participant('Bob', {
    acceptTerms: Fun([], Bool),
    ...shared,
  });

  const informTimeout = () => {
    each([A, B], () => {
      interact.informTimeout();
    })
  }

  init();

  A.publish()
    .pay(4000)
    // .timeout(relativeTime(), () => closeTo(Alice, informTimeout));
  commit();

  B.publish();
  commit();

  B.only(() => {
    const isTermAccepted = declassify(interact.acceptTerms());
  });

  each([A, B], () => {
    interact.viewCountdown(DEADLINE);
  });

  B.publish(isTermAccepted);

  const TIME_TO_TERMINATE = relativeTime(DEADLINE);

  var [continueLoop] = [true];
  invariant(balance() == 4000);

  while (continueLoop) {
    commit();

    A.only(() => {
      const isHere = declassify(interact.flickSwitch());
    });

    A.publish(isHere)
      .timeout(absoluteTime(120), () => closeTo(A, informTimeout));
    
    each([A, B], () => {
      interact.getUpdate(isHere);
    });
  }

  // write your program here
  exit();
});

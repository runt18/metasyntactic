package com.google.automata.compiler.python.scanner.literals;

import com.google.automata.compiler.util.UnimplementedException;

/**
 * Created by IntelliJ IDEA. User: cyrusn Date: Jun 24, 2008 Time: 2:56:17 PM To change this template use File |
 * Settings | File Templates.
 */
public class ImaginaryNumberLiteralToken extends LiteralToken<Double> {
  public ImaginaryNumberLiteralToken(String text) {
    super(text);
  }

  @Override public Double getValue() {
    throw new UnimplementedException();
  }
}

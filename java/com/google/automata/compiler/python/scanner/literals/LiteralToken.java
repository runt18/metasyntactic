package com.google.automata.compiler.python.scanner.literals;

import com.google.automata.compiler.python.scanner.PythonToken;

/**
 * Created by IntelliJ IDEA.
 * User: cyrusn
 * Date: Jun 22, 2008
 * Time: 5:36:03 PM
 * To change this template use File | Settings | File Templates.
 */
public abstract class LiteralToken<T> extends PythonToken {
  protected LiteralToken(String text) {
    super(text);
  }

  public abstract T getValue();

  @Override public Type getTokenType() {
    return Type.Literal;
  }

  public static int typeValue() {
    return type().ordinal();
  }

  private static Type type() {
    return Type.Literal;
  }
}
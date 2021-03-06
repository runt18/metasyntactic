// Copyright 2008 Google Inc. All rights reserved.

package org.metasyntactic.automata.compiler.framework.parsers.packrat.expressions;

public class CharacterExpression extends Expression {
  private final char character;

  CharacterExpression(char character) {

    this.character = character;
  }

  public char getCharacter() {
    return character;
  }

   public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof CharacterExpression)) {
      return false;
    }

    CharacterExpression that = (CharacterExpression) o;

    return this.character == that.character;
  }

   public int hashCodeWorker() {
    return character;
  }

   public <TInput, TResult> TResult accept(ExpressionVisitor<TInput, TResult> visitor) {
    return visitor.visit(this);
  }

   public <TInput> void accept(ExpressionVoidVisitor<TInput> visitor) {
    visitor.visit(this);
  }

   public String toString() {
    return "'" + character + "'";
  }
}

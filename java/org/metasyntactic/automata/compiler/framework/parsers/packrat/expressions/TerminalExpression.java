// Copyright 2008 Google Inc. All rights reserved.

package org.metasyntactic.automata.compiler.framework.parsers.packrat.expressions;

import org.metasyntactic.common.base.Preconditions;

/**
 * An atomic parsing expression consisting of a single terminal succeeds if the first character of the input string
 * matches that terminal, and in that case consumes the input character; otherwise the expression yields a failure
 * result.
 *
 * @author cyrusn@google.com (Cyrus Najmabadi)
 */
public class TerminalExpression extends Expression {
  private final String terminal;

  TerminalExpression(String terminal) {
    Preconditions.checkNotNull(terminal);

    this.terminal = terminal;
  }

  public String getTerminal() {
    return terminal;
  }

   public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof TerminalExpression)) {
      return false;
    }

    TerminalExpression that = (TerminalExpression) o;

    if (!terminal.equals(that.terminal)) {
      return false;
    }

    return true;
  }

   public int hashCodeWorker() {
    return terminal.hashCode();
  }

   public <TInput, TResult> TResult accept(ExpressionVisitor<TInput, TResult> visitor) {
    return visitor.visit(this);
  }

   public <TInput> void accept(ExpressionVoidVisitor<TInput> visitor) {
    visitor.visit(this);
  }

   public String toString() {
    if (terminal.contains("\"")) {
      return "'" + terminal + "'";
    } else {
      return '"' + terminal + '"';
    }
  }
}


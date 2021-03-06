// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
package org.metasyntactic.utilities;

import android.content.res.Resources;
import android.graphics.drawable.Drawable;
import static org.metasyntactic.utilities.CollectionUtilities.isEmpty;
import org.metasyntactic.activities.R;
import org.metasyntactic.caches.scores.ScoreType;
import org.metasyntactic.data.Movie;
import static org.metasyntactic.utilities.StringUtilities.isNullOrEmpty;

import java.lang.ref.SoftReference;
import java.text.DateFormat;
import java.util.Collection;
import java.util.Date;
import java.util.List;

public class MovieViewUtilities {
  public static final int MENU_SORT = 1;
  public static final int MENU_THEATER = 2;
  public static final int MENU_UPCOMING = 3;
  public static final int MENU_SETTINGS = 4;
  public static final int MENU_MOVIES = 5;
  public static final int MENU_TRAILERS = 6;
  public static final int MENU_REVIEWS = 7;
  public static final int MENU_IMDB = 8;
  public static final int MENU_SHOWTIMES = 9;
  public static final int MENU_SEARCH = 10;
  public static final int MENU_SEND_FEEDBACK = 11;
  public static final int MENU_LICENSE = 12;
  public static final int MENU_CREDITS = 13;

  // Constants for movies sort
  private static final int MovieTitle = 0;
  private static final int Release = 1;
  // constants for Theaters sort
  private static SoftReference<Drawable> rotten_full_drawable;
  private static SoftReference<Drawable> rating_unknown_drawable;
  private static SoftReference<Drawable> fresh_drawable;
  private static SoftReference<Drawable> rating_red_drawable;
  private static SoftReference<Drawable> rating_green_drawable;
  private static SoftReference<Drawable> rating_yellow_drawable;

  private MovieViewUtilities() {
  }

  /**
   * Formats the movie rating for display. For example if a movie is rated PG
   * 13, the ratings string is "Rated PG-13.". If a movie is unrated then the
   * ratings string is "Unrated."
   *
   * @param rating Movie rating.
   * @param res    Context resources handle.
   * @return the formatted rating
   */
  public static String formatRatings(final String rating, final Resources res) {
    if (isNullOrEmpty(rating)) {
      return res.getString(R.string.unrated);
    } else {
      return res.getString(R.string.rated_string, rating);
    }
  }

  /**
   * Formats the movie length for display. The movie length is displayed as "x
   * hours y minutes".
   *
   * @param length Movie length in minutes.
   * @param res    Context resources handle.
   * @return the formatted length
   */
  public static String formatLength(final int length, final Resources res) {
    String hoursString = "";
    String minutesString = "";
    if (length > 0) {
      final int hours = length / 60;
      final int minutes = length % 60;
      if (hours == 1) {
        hoursString = res.getString(R.string.one_hour);
      } else if (hours > 1) {
        hoursString = res.getString(R.string.number_hours, hours);
      }
      if (minutes == 1) {
        minutesString = res.getString(R.string.one_minute);
      } else if (minutes > 1) {
        minutesString = res.getString(R.string.number_minutes, minutes);
      }
    }
    return res.getString(R.string.string_string, hoursString, minutesString);
  }

  public static String formatListToString(final Collection<String> list) {
    if (isEmpty(list)) {
      return "Unknown";
    } else {
      final String listStr = list.toString();
      return listStr.substring(1, listStr.length() - 1);
    }
  }

  public static Drawable formatScoreDrawable(final int score, final Object scoreType, final Resources res) {
    if (scoreType == ScoreType.RottenTomatoes) {
      return formatRottenTomatoesDrawable(score, res);
    }
    return formatBasicSquareDrawable(score, res);
  }

  private static Drawable formatRottenTomatoesDrawable(final int score, final Resources res) {
    if (rating_unknown_drawable == null || rating_unknown_drawable.get() == null) {
      rating_unknown_drawable = new SoftReference<Drawable>(res.getDrawable(R.drawable.rating_unknown));
    }
    Drawable scoreDrawable = rating_unknown_drawable.get();
    if (score >= 0 && score <= 100) {
      if (score >= 60) {
        if (fresh_drawable == null || fresh_drawable.get() == null) {
          fresh_drawable = new SoftReference<Drawable>(res.getDrawable(R.drawable.fresh));
        }
        scoreDrawable = fresh_drawable.get();
      } else {
        if (rotten_full_drawable == null || rotten_full_drawable.get() == null) {
          rotten_full_drawable = new SoftReference<Drawable>(res.getDrawable(R.drawable.rotten_full));
        }
        scoreDrawable = rotten_full_drawable.get();
      }
    }
    return scoreDrawable;
  }

  public static Drawable formatBasicSquareDrawable(final int score, final Resources res) {
    if (rating_unknown_drawable == null || rating_unknown_drawable.get() == null) {
      rating_unknown_drawable = new SoftReference<Drawable>(res.getDrawable(R.drawable.rating_unknown));
    }
    Drawable scoreDrawable = rating_unknown_drawable.get();
    if (score >= 0 && score <= 40) {
      if (rating_red_drawable == null || rating_red_drawable.get() == null) {
        rating_red_drawable = new SoftReference<Drawable>(res.getDrawable(R.drawable.rating_red));
      }
      scoreDrawable = rating_red_drawable.get();
    } else if (score > 40 && score <= 60) {
      if (rating_yellow_drawable == null || rating_yellow_drawable.get() == null) {
        rating_yellow_drawable = new SoftReference<Drawable>(res.getDrawable(R.drawable.rating_yellow));
      }
      scoreDrawable = rating_yellow_drawable.get();
    } else if (score > 60 && score <= 100) {
      if (rating_green_drawable == null || rating_green_drawable.get() == null) {
        rating_green_drawable = new SoftReference<Drawable>(res.getDrawable(R.drawable.rating_green));
      }
      scoreDrawable = rating_green_drawable.get();
    }
    return scoreDrawable;
  }

  public static String getHeader(final List<Movie> movies, final int position, final int sortIndex) {
    switch (sortIndex) {
    case MovieTitle:
      if (position == 0) {
        return String.valueOf(movies.get(0).getDisplayTitle().charAt(0));
      }
      if (movies.get(position).getDisplayTitle().charAt(0) != movies.get(position - 1).getDisplayTitle().charAt(0)) {
        return String.valueOf(movies.get(position).getDisplayTitle().charAt(0));
      }
      break;
    case Release:
      final Date d1 = movies.get(position).getReleaseDate();
      final DateFormat df = DateFormat.getDateInstance(DateFormat.LONG);
      final String dateStr;
      if (d1 != null) {
        dateStr = df.format(d1);
      } else {
        dateStr = null;
      }
      if (position == 0) {
        return dateStr;
      }
      final Date d2 = movies.get(position - 1).getReleaseDate();
      if (d2 != null && d1 != null && !d1.equals(d2)) {
        return dateStr;
      }
      return null;
    }
    return null;
  }

  public static void cleanUpDrawables() {
    if (rotten_full_drawable != null && rotten_full_drawable.get() != null) {
      rotten_full_drawable.get().setCallback(null);
    }
    if (fresh_drawable != null && fresh_drawable.get() != null) {
      fresh_drawable.get().setCallback(null);
    }
    if (rating_unknown_drawable != null && rating_unknown_drawable.get() != null) {
      rating_unknown_drawable.get().setCallback(null);
    }
    if (rating_yellow_drawable != null && rating_yellow_drawable.get() != null) {
      rating_yellow_drawable.get().setCallback(null);
    }
    if (rating_red_drawable != null && rating_red_drawable.get() != null) {
      rating_red_drawable.get().setCallback(null);
    }
    if (rating_green_drawable != null && rating_green_drawable.get() != null) {
      rating_green_drawable.get().setCallback(null);
    }
  }
}

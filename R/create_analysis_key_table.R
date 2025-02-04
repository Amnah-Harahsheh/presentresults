#' Create a table from the analysis_key and results object
#'
#'  Helper function to turn a analysis_key to a table. It will return a dataframe with
#'  analysis_var_x, analysis_var_value_x, group_var_x, group_var_value_x, nb_analysis_var,
#'  nb_group_var:
#'  - Where YY_var_x are the variable names for the dependent and
#'  independent variables.
#'  - Where YY_var_value_x are the values for the dependent and independent variables.
#'  - Where x is the number of the variable by order of grouping.
#'  - nb_xx is the number of variable used in the grouping.
#'
#' @param .results result object with an analysis key
#' @param analysis_key character vector with the name of the analysis key column.
#' Default is "analysis key"
#'
#' @return a dataframe with the analysis key and analysis_var_x, analysis_var_value_x, group_var_x,
#' group_var_value_x, nb_analysis_var and nb_group_var
#' @export
#'
#' @examples
#' create_analysis_key_table(presentresults_resultstable)
create_analysis_key_table <- function(.results, analysis_key = "analysis_key") {
  # check for @/@ format for the different types
  if (.results %>%
    dplyr::pull(!!rlang::sym(analysis_key)) %>%
    stringr::str_split(" @/@ ", simplify = TRUE) %>%
    dim() %>%
    `[[`(2) != 3) {
    stop("Analysis keys does not seem to follow the correct format")
  }

  key_table <- .results %>%
    dplyr::select(dplyr::all_of(c(analysis_key))) %>%
    tidyr::separate(
      analysis_key,
      c("analysis_type", "analysis_var", "group_var"),
      sep = " @/@ ",
      remove = FALSE
    ) %>%
    dplyr::mutate(
      nb_analysis_var = ceiling(stringr::str_count(analysis_var, "~/~") / 2),
      nb_group_var = ceiling(stringr::str_count(group_var, "~/~") / 2)
    )

  analysis_var_split <-
    paste0(rep(
      c("analysis_var_", "analysis_var_value_"),
      max(key_table$nb_analysis_var)
    ), rep(c(1:max(
      key_table$nb_analysis_var
    )), each = 2))
  group_var_split <-
    paste0(rep(
      c("group_var_", "group_var_value_"),
      max(key_table$nb_group_var)
    ), rep(c(1:max(
      key_table$nb_group_var
    )), each = 2))

  key_table <- key_table %>%
    tidyr::separate(analysis_var,
      analysis_var_split,
      sep = " ~/~ "
    ) %>%
    tidyr::separate(group_var,
      group_var_split,
      sep = " ~/~ "
    )

  return(key_table)
}

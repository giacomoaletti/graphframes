#' PageRank
#'
#' @template roxlate-gf-x
#' @param tol Tolerance.
#' @param reset_probability Reset probability.
#' @param max_iter Maximum number of iterations.
#' @param source_id (Optional) Source vertex for a personalized pagerank.
#' @template roxlate-gf-dots
#'
#' @examples
#' \dontrun{
#' g <- gf_friends(sc)
#' gf_pagerank(g, reset_probability = 0.15, tol = 0.01)
#' }
#' @export
gf_pagerank <- function(x, tol = NULL, reset_probability = 0.15, max_iter = NULL,
                        source_id = NULL, ...) {
  tol <- cast_nullable_scalar_double(tol)
  reset_probability <- cast_scalar_double(reset_probability)
  max_iter <- cast_nullable_scalar_integer(max_iter)
  source_id <- cast_nullable_string(source_id)

  gf <- spark_graphframe(x)

  if (is.null(tol) && is.null(max_iter))
    stop("One of 'tol' and 'max_iter' must be specified")
  if (!is.null(tol) && !is.null(max_iter))
    stop("You cannot specify both 'tol' and 'max_iter'")

  algo <- gf %>%
    invoke("pageRank") %>%
    invoke("resetProbability", reset_probability)

  if (!is.null(tol))
    algo <- invoke(algo, "tol", tol)

  if (!is.null(max_iter))
    algo <- invoke(algo, "maxIter", max_iter)

  if (!is.null(source_id))
    algo <- invoke(algo, "sourceId", source_id)

  algo %>%
    invoke("run") %>%
    gf_register()
}

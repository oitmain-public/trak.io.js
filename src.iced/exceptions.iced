define [
  'exception',
  'exceptions/data_object_invalid_json',
  'exceptions/duplicated_distinct_ids',
  'exceptions/internal_service_error',
  'exceptions/invalid_token',
  'exceptions/missing_parameter',
  'exceptions/person_not_found',
  'exceptions/properties_object_invalid',
  'exceptions/route_not_found',
  'exceptions/timeout',
  'exceptions/unknown'
], (
  Exception,
  DataObjectInvalidJson,
  DuplicatedDistinctIds,
  InternalServiceError,
  InvalidToken,
  MissingParameter,
  PersonNotFound,
  PropertiesObjectInvalid,
  RouteNotFound,
  Timeout,
  Unknown
) ->

  return {
    Exception: Exception,
    DataObjectInvalidJson: DataObjectInvalidJson,
    DuplicatedDistinctIds: DuplicatedDistinctIds,
    InternalServiceError: InternalServiceError,
    InvalidToken: InvalidToken,
    MissingParameter: MissingParameter,
    PersonNotFound: PersonNotFound,
    PropertiesObjectInvalid: PropertiesObjectInvalid,
    RouteNotFound: RouteNotFound,
    Timeout: Timeout,
    Unknown: Unknown
  }

sealed class UiState<T> {}

class UiStateLoading<T> extends UiState<T> {}

class UiStateSuccess<T> extends UiState<T> {
  final T data;
  UiStateSuccess(this.data);
}

class UiStateEmpty<T> extends UiState<T> {}

class UiStateError<T> extends UiState<T> {
  final String message;
  final void Function() retry;

  UiStateError({required this.message, required this.retry});
}

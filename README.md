# AlertPresenterController
Test project with examples of using AlertControllerPresenter.

```AlertControllerPresenter``` present ```UIAlertController``` with ```AlertPresentationOperation``` on custon ```AlertWindow```.
```AlertWindow``` is higher than keyboard window and present ```UIAlertController``` over the keyboard.
```AlertPresentationOperation``` give us posibility to present only one ```UIAlertController``` in time, or one by one, we have rule for this in presenter. Also ```AlertPresentationOperation``` syncronize AlertWindow hidden state.
```AlertControllerPresenter``` work properly on iPad too.

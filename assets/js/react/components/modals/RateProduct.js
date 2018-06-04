import React, { PureComponent } from 'react'
import PropTypes from 'prop-types'
import Modal from './Modal'
import cn from 'classnames'

export default class RateProduct extends PureComponent {
  static propTypes = {
    onSubmit: PropTypes.func.isRequired,
    onHide: PropTypes.func.isRequired
  }

  state = {
    rating: null,
    ratingTouched: false,
  }

  handleRatingChange = e => {
    this.setState({
      rating: parseInt(e.target.value, 10),
      ratingTouched: true,
    })
  }

  handleRejectRating = () => {
    this.setState({ rating: null })
    this.props.onHide()
  }

  render() {
    const { onSubmit, ...modalProps } = this.props
    const radioInputs = Array.from({ length: 5 }, (element, index) => index + 1)
    const { ratingTouched } = this.state
    const saveButtonClassNames = cn(
      'button',
      {
        'button--dark': ratingTouched,
        'button--disabled': !ratingTouched
      }
    )

    return (
      <Modal {...modalProps}>
        <img src="/images/close.svg" onClick={this.props.onHide}/>
        <h2 className="modal__heading">Rate the book</h2>
        <form
          className="rating"
          onSubmit={e => {
            e.preventDefault()
            onSubmit(this.state.rating)
            this.setState({ rating: null })
          }}
        >
          <div className="rating__radios-wrapper">
            {
              radioInputs.map(element => (
                <div className="rating__radio-option" key={`radio${element}`}>
                  <label className="rating__radio-label" htmlFor={`opt${element}`}>
                    { element }
                  </label>
                  <input
                    className="rating__radio-input"
                    id={`opt${element}`}
                    type="radio"
                    name="rating"
                    value={element}
                    checked={this.state.rating === element}
                    onChange={this.handleRatingChange}
                  />
                  <div className="rating__radiobutton"></div>
                </div>
              ))
            }
          </div>
          <div className="rating__buttons-wrapper">
            <button className="button button--transparent" onClick={this.handleRejectRating}>Cancel</button>
            <button
              className={saveButtonClassNames}
              type="submit"
              disabled={!ratingTouched}
            >
              Save
            </button>
          </div>
        </form>
      </Modal>
    )
  }
}
